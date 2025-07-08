import { forwardRef } from 'react'
import { clsx } from 'clsx'

const Card = forwardRef(({ 
  children, 
  className = '', 
  padding = 'default',
  shadow = 'default',
  ...props 
}, ref) => {
  const paddingClasses = {
    none: '',
    sm: 'p-4',
    default: 'p-6',
    lg: 'p-8',
    xl: 'p-10'
  }
  
  const shadowClasses = {
    none: '',
    sm: 'shadow-sm',
    default: 'shadow',
    lg: 'shadow-lg',
    xl: 'shadow-xl'
  }

  return (
    <div
      ref={ref}
      className={clsx(
        'bg-white rounded-lg border border-gray-200',
        paddingClasses[padding],
        shadowClasses[shadow],
        className
      )}
      {...props}
    >
      {children}
    </div>
  )
})

Card.displayName = 'Card'

const CardHeader = forwardRef(({ 
  children, 
  className = '', 
  ...props 
}, ref) => {
  return (
    <div
      ref={ref}
      className={clsx('border-b border-gray-200 pb-4 mb-4', className)}
      {...props}
    >
      {children}
    </div>
  )
})

CardHeader.displayName = 'CardHeader'

const CardTitle = forwardRef(({ 
  children, 
  className = '', 
  ...props 
}, ref) => {
  return (
    <h3
      ref={ref}
      className={clsx('text-lg font-semibold text-gray-900', className)}
      {...props}
    >
      {children}
    </h3>
  )
})

CardTitle.displayName = 'CardTitle'

const CardContent = forwardRef(({ 
  children, 
  className = '', 
  ...props 
}, ref) => {
  return (
    <div
      ref={ref}
      className={clsx('', className)}
      {...props}
    >
      {children}
    </div>
  )
})

CardContent.displayName = 'CardContent'

const CardFooter = forwardRef(({ 
  children, 
  className = '', 
  ...props 
}, ref) => {
  return (
    <div
      ref={ref}
      className={clsx('border-t border-gray-200 pt-4 mt-4', className)}
      {...props}
    >
      {children}
    </div>
  )
})

CardFooter.displayName = 'CardFooter'

export { Card, CardHeader, CardTitle, CardContent, CardFooter } 